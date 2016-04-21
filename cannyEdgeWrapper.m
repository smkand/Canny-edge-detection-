% Wrapper for cannEd.m
clc
clear all
close all

A  = imread('pillsect.pnm');
B = cannEd(A);
figure,
imshow(B);
