Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9CA786B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 10:59:33 -0400 (EDT)
Message-ID: <521627B6.6080603@parallels.com>
Date: Thu, 22 Aug 2013 19:01:10 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: strictlimit feature -v4
References: <20130821135427.20334.79477.stgit@maximpc.sw.ru> <20130821133804.87ca602dd864df712e67342a@linux-foundation.org> <5215E4B7.3020003@parallels.com> <20130822144121.GA620@localhost>
In-Reply-To: <20130822144121.GA620@localhost>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, jack@suse.cz, dev@parallels.com, miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, xemul@parallels.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, devel@openvz.org, mgorman@suse.de

Hi,

08/22/2013 06:41 PM, Fengguang Wu D?D,N?DuN?:
> Hi Maxim,
>
>>> I think I'll apply it to -mm for now to get a bit of testing, but would
>>> very much like it if Fengguang could find time to review the
>>> implementation, please.
>> Great! Fengguang, please...
> I'm so sorry for the delays!
>
> I'd like to test the patches out and take a look at its runtime
> behaviors. I've managed to setup general dd writeback tests. Do you
> happen to have some scripts that can specifically test out the fuse
> cases?

I used ordinary dd over fuse mount for testing. But fuse setup was 
tricky. I'll send a writeup of my test environment to you tomorrow.

Thanks,
Maxim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
