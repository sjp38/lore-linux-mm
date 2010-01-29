Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A5B446B007B
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 00:06:10 -0500 (EST)
Message-ID: <4B626C90.7070809@zytor.com>
Date: Thu, 28 Jan 2010 21:05:20 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [Security] DoS on x86_64
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com> <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain> <4B621D48.4090203@zytor.com> <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain>
Content-Type: multipart/mixed;
 boundary="------------060906030803040601040508"
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060906030803040601040508
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 01/28/2010 08:43 PM, Linus Torvalds wrote:
> 
> 
> On Thu, 28 Jan 2010, H. Peter Anvin wrote:
>>
>> I think your splitup patch might still be a good idea in the sense that
>> your flush_old_exec() is the parts that can fail.
>>
>> So I think the splitup patch, plus removing delayed effects, might be
>> the right thing to do?  Testing that approach now...
> 
> So I didn't see any patch from you, so here's my try instead. 
> 

Sorry, was chasing bugs.  These two patches on top of your original
split patch works for me in testing so far.  I'm going to compare the
code with what your two new patches produce.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.


--------------060906030803040601040508
Content-Type: text/x-patch;
 name="0001-Fix-the-flush_old_exec-patch-from-Linus.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-Fix-the-flush_old_exec-patch-from-Linus.patch"


--------------060906030803040601040508--
