Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EC2156B00D5
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 12:41:13 -0400 (EDT)
Received: by iwn9 with SMTP id 9so841997iwn.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 09:41:12 -0700 (PDT)
Date: Thu, 4 Nov 2010 00:37:20 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
Message-ID: <20101103163702.GA4683@hack>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net> <AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com> <20101031173336.GA28141@balbir.in.ibm.com> <alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net> <alpine.DEB.2.00.1011030937580.10599@router.home> <AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: jovi zhang <bookjovi@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Jesper Juhl <jj@chaosbits.net>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 11:20:32PM +0800, jovi zhang wrote:
>On Wed, Nov 3, 2010 at 10:38 PM, Christoph Lameter <cl@linux.com> wrote:
>> On Mon, 1 Nov 2010, Jesper Juhl wrote:
>>
>>> On Sun, 31 Oct 2010, Balbir Singh wrote:
>>
>>> > > There are so many placed need vzalloc.
>>> > > Thanks, Jesper.
>>
>>
>> Could we avoid this painful exercise with a "semantic patch"?
>>
>Can we make a grep script to walk all files to find vzalloc usage like this?
>No need to send patch mail one by one like this.

No, grep doesn't understand C. :)

-- 
Live like a child, think like the god.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
