Message-Id: <l0313031cb745811cfc17@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0106061705250.3769-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 7 Jun 2001 20:07:15 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] Reap dead swap cache earlier v2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>As suggested by Linus, I've cleaned the reapswap code to be contained
>inside an inline function. (yes, the if statement is really ugly)

I can't seem to find the patch which adds this behaviour to the background
scanning.  Can someone point me to it?

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
