Message-ID: <39E246DB.91B5517D@onetelnet.fr>
Date: Tue, 10 Oct 2000 00:29:47 +0200
From: FORT David <epopo@onetelnet.fr>
MIME-Version: 1.0
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
References: <Pine.LNX.4.21.0010092223100.8045-100000@elte.hu>
Content-Type: multipart/alternative;
 boundary="------------88B1A5B9CC53204E7DA3773A"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--------------88B1A5B9CC53204E7DA3773A
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

Ingo Molnar wrote:

> On Mon, 9 Oct 2000, Rik van Riel wrote:
>
> > > so dns helper is killed first, then netscape. (my idea might not
> > > make sense though.)
> >
> > It makes some sense, but I don't think OOM is something that
> > occurs often enough to care about it /that/ much...
>
> i'm trying to handle Andrea's case, the init=/bin/bash manual-bootup case,
> with 4MB RAM and no swap, where the admin tries to exec a 2MB process. I
> think it's a legitimate concern - i cannot know in advance whether a
> freshly started process would trigger an OOM or not.
>
>         Ingo
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> Please read the FAQ at http://www.tux.org/lkml/

Everybody seems to agreed that depending of the goal, we may kill interactive
process or niced process. What
about a tunable OOM killer with a /proc/ file which would indicate which sort
of process to kill ?

--
%--IRIN->-Institut-de-Recherche-en-Informatique-de-Nantes-----------------%
% FORT David,                                                             %
% 7 avenue de la morvandiere                                   0240726275 %
% 44470 Thouare, France                                epopo@onetelnet.fr %
% ICU:78064991   AIM: enlighted popo             fort@irin.univ-nantes.fr %
%--LINUX-HTTPD-PIOGENE----------------------------------------------------%
%  -datamining <-/                        |   .~.                         %
%  -networking/flashed PHP3 coming soon   |   /V\        L  I  N  U  X    %
%  -opensource                            |  // \\     >Fear the Penguin< %
%  -GNOME/enlightenment/GIMP              | /(   )\                       %
%           feel enlighted....            |  ^^-^^                        %
%                             http://ibonneace.dyndns.org/ when connected %
%-------------------------------------------------------------------------%



--------------88B1A5B9CC53204E7DA3773A
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
Ingo Molnar wrote:
<blockquote TYPE=CITE>On Mon, 9 Oct 2000, Rik van Riel wrote:
<p>> > so dns helper is killed first, then netscape. (my idea might not
<br>> > make sense though.)
<br>>
<br>> It makes some sense, but I don't think OOM is something that
<br>> occurs often enough to care about it /that/ much...
<p>i'm trying to handle Andrea's case, the init=/bin/bash manual-bootup
case,
<br>with 4MB RAM and no swap, where the admin tries to exec a 2MB process.
I
<br>think it's a legitimate concern - i cannot know in advance whether
a
<br>freshly started process would trigger an OOM or not.
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Ingo
<p>-
<br>To unsubscribe from this list: send the line "unsubscribe linux-kernel"
in
<br>the body of a message to majordomo@vger.kernel.org
<br>Please read the FAQ at <a href="http://www.tux.org/lkml/">http://www.tux.org/lkml/</a></blockquote>
Everybody seems to agreed that depending of the goal, we may kill interactive
process or niced process. What
<br>about a tunable OOM killer with a /proc/ file which would indicate
which sort of process to kill ?
<pre>--&nbsp;
%--IRIN->-Institut-de-Recherche-en-Informatique-de-Nantes-----------------%
% FORT David,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %
% 7 avenue de la morvandi&egrave;re&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0240726275 %
% 44470 Thouare, France&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; epopo@onetelnet.fr %
% ICU:78064991&nbsp;&nbsp; AIM: enlighted popo&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; fort@irin.univ-nantes.fr %
%--LINUX-HTTPD-PIOGENE----------------------------------------------------%
%&nbsp; -datamining &lt;-/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp; .~.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %
%&nbsp; -networking/flashed PHP3 coming soon&nbsp;&nbsp; |&nbsp;&nbsp; /V\&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; L&nbsp; I&nbsp; N&nbsp; U&nbsp; X&nbsp;&nbsp;&nbsp; %
%&nbsp; -opensource&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp; // \\&nbsp;&nbsp;&nbsp;&nbsp; >Fear the Penguin&lt; %
%&nbsp; -GNOME/enlightenment/GIMP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | /(&nbsp;&nbsp; )\&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %
%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; feel enlighted....&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp; ^^-^^&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %
%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <A HREF="http://ibonneace.dyndns.org/">http://ibonneace.dyndns.org/</A> when connected %
%-------------------------------------------------------------------------%</pre>
&nbsp;</html>

--------------88B1A5B9CC53204E7DA3773A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
