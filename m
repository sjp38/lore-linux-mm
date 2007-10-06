Received: by rv-out-0910.google.com with SMTP id l15so212960rvb
        for <linux-mm@kvack.org>; Fri, 05 Oct 2007 18:27:12 -0700 (PDT)
Date: Sat, 6 Oct 2007 09:21:25 +0800
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch]Documentation/vm/slabinfo.c: clean up this code
Message-ID: <20071006012125.GA2436@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
References: <20071005124614.GD12498@hacking> <Pine.LNX.4.64.0710051216250.17345@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710051216250.17345@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 05, 2007 at 12:17:41PM -0700, Christoph Lameter wrote:
>On Fri, 5 Oct 2007, WANG Cong wrote:
>
>> 
>> This patch does the following cleanups for Documentation/vm/slabinfo.c:
>> 
>> 	- Fix two memory leaks;
>
>For user space code? Memory will be released as soon as the program 
>terminates.

Yes, it's of course in user space. But there really exists memory leaks,
since strdup(3) uses malloc(3) to allocate memory for new string, we
should use free(3) to free the memory, or this memory will be lost.

Regards. ;)


WANG Cong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
