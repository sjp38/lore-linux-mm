Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 451F56B0008
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 18:00:09 -0500 (EST)
Date: Tue, 12 Feb 2013 00:00:03 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 1/2] add helper for highmem checks
Message-ID: <20130211230003.GG2683@pd.tnic>
References: <20130208202813.62965F25@kernel.stglabs.ibm.com>
 <20130209094121.GB17728@pd.tnic>
 <20130209104751.GC17728@pd.tnic>
 <51192B39.9060501@linux.vnet.ibm.com>
 <20130211182826.GE2683@pd.tnic>
 <7794bbcd-5d5a-4e81-87fd-68b0aa17a556@email.android.com>
 <20130211223405.GF2683@pd.tnic>
 <511974D3.8020900@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <511974D3.8020900@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de

On Mon, Feb 11, 2013 at 02:46:43PM -0800, H. Peter Anvin wrote:
> The X server itself used to do that. Are you saying that wdm is a
> *privileged process*?

Nah, it is a simple display manager you start with /etc/init.d/wdm init
script. Like the other display managers gdm, kdm, etc.

But it looks like wdm has copied stuff from xdm (from the README):

"Wdm is a modification of XFree86's xdm package for graphically handling
authentication and system login. Most of xdm has been preserved (XFree86
4.2.1.1) with the Login interface based on a WINGs implementation using
Tom Rothamel's "external greet" interface (see AUTHORS)."

And from looking at the part in the source which does the /dev/mem
accesses, it comes from XFree86's source apparently, this is at the
beginning of src/wdm/genauth.c:

/* $Xorg: genauth.c,v 1.5 2001/02/09 02:05:40 xorgcvs Exp $ */
/*

   Copyright 1988, 1998  The Open Group
...

so this explains why it behaves like the X server in that respect.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
