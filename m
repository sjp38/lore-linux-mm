Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F1A96B00FF
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 22:01:45 -0400 (EDT)
Received: by iwn38 with SMTP id 38so2163611iwn.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 19:01:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1010280848130.25874@router.home>
References: <AANLkTikn_44WcCBmWUW=8E3q3=cznZNx=dHdOcgZSKgH@mail.gmail.com>
 <AANLkTin32b4SaC0PTJpX8Pg4anQ3aSMUZFe0QFbt9y36@mail.gmail.com>
 <AANLkTim=6Oan-CSnGMD1CTsd5iGRr98X44TAcirQt7Q_@mail.gmail.com>
 <alpine.DEB.2.00.1010271503360.6255@router.home> <AANLkTikX2LkCfEAuJAaWJ5FsWC25mkQi2qLCSe=L=4q1@mail.gmail.com>
 <alpine.DEB.2.00.1010280848130.25874@router.home>
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Fri, 29 Oct 2010 07:31:06 +0530
Message-ID: <AANLkTikZh4J6qKBJirxphB2s7MU0BHU50gQwwpVRYOko@mail.gmail.com>
Subject: Re: TMPFS Maximum File Size
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 7:19 PM, Christoph Lameter <cl@linux.com> wrote:
>> I still wonder why this happens only with IBM+SLES 11 kernel ? Same HW
>> works with later kernels ?
>
> I have no idea how Novell hacks up their SLES11 kernels. Good to hear that
> we do not have the issue upstream.
>
>
Could this be a SLES 11 issue ? Even SLES 11 works well with different hardware.
I thought this is an IBM hardware issue.

Thankx.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
