Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E2C916B00B3
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 22:55:04 -0400 (EDT)
Message-ID: <51510E1E.70508@redhat.com>
Date: Tue, 26 Mar 2013 10:55:26 +0800
From: Weiping Pan <wpan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] typo: replace kernelcore with Movable
References: <5aed74b1520f495521fe97b99b714cfe7572faa1.1357359930.git.wpan@redhat.com> <20130107135959.GE3885@suse.de>
In-Reply-To: <20130107135959.GE3885@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On 01/07/2013 09:59 PM, Mel Gorman wrote:
> On Sat, Jan 05, 2013 at 12:29:17PM +0800, Weiping Pan wrote:
>> Han Pingtian found a typo in Documentation/kernel-parameters.txt
>> about "kernelcore=", that "kernelcore" should be replaced with "Movable" here.
>>
>> Signed-off-by: Weiping Pan<wpan@redhat.com>
> Acked-by: Mel Gorman<mgorman@suse.de>
>
Hi,

I see that this tiny patch has not been merged yet,
maybe the maintainer omitted it.

Should I resend it ?

thanks
Weiping Pan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
