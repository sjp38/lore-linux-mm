Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 7049A6B0008
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 18:02:19 -0500 (EST)
Message-ID: <5119786B.9020400@zytor.com>
Date: Mon, 11 Feb 2013 15:02:03 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] add helper for highmem checks
References: <20130208202813.62965F25@kernel.stglabs.ibm.com> <20130209094121.GB17728@pd.tnic> <20130209104751.GC17728@pd.tnic> <51192B39.9060501@linux.vnet.ibm.com> <20130211182826.GE2683@pd.tnic> <7794bbcd-5d5a-4e81-87fd-68b0aa17a556@email.android.com> <20130211223405.GF2683@pd.tnic> <511974D3.8020900@zytor.com> <20130211230003.GG2683@pd.tnic>
In-Reply-To: <20130211230003.GG2683@pd.tnic>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de

On 02/11/2013 03:00 PM, Borislav Petkov wrote:
> On Mon, Feb 11, 2013 at 02:46:43PM -0800, H. Peter Anvin wrote:
>> The X server itself used to do that. Are you saying that wdm is a
>> *privileged process*?
> 
> Nah, it is a simple display manager you start with /etc/init.d/wdm init
> script. Like the other display managers gdm, kdm, etc.
> 
> But it looks like wdm has copied stuff from xdm (from the README):
> 
> "Wdm is a modification of XFree86's xdm package for graphically handling
> authentication and system login. Most of xdm has been preserved (XFree86
> 4.2.1.1) with the Login interface based on a WINGs implementation using
> Tom Rothamel's "external greet" interface (see AUTHORS)."
> 
> And from looking at the part in the source which does the /dev/mem
> accesses, it comes from XFree86's source apparently, this is at the
> beginning of src/wdm/genauth.c:
> 

Oh, it's not a *window manager*, it is a *session manager* (display
manager), and so it runs as root by default.

Plug the damned hole, submit a bug report to Debian to change the
default, and let's be done with it.  That being said, it did flag a real
problem, but what it is doing is dangerous.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
