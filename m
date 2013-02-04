Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id D7B666B0034
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 11:57:14 -0500 (EST)
Message-ID: <510FE866.9090600@wwwdotorg.org>
Date: Mon, 04 Feb 2013 09:57:10 -0700
From: Stephen Warren <swarren@wwwdotorg.org>
MIME-Version: 1.0
Subject: Re: CPU hotplug hang due to "swap: make each swap partition have
 one address_space"
References: <510C9DE9.9040207@wwwdotorg.org> <20130204023646.GA321@kernel.org>
In-Reply-To: <20130204023646.GA321@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Shaohua Li <shli@fusionio.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Joseph Lo <josephl@nvidia.com>

On 02/03/2013 07:36 PM, Shaohua Li wrote:
> On Fri, Feb 01, 2013 at 10:02:33PM -0700, Stephen Warren wrote:
>> Shaohua,
>>
>> In next-20130128, commit 174f064 "swap: make each swap partition have
>> one address_space" (from the mm/akpm tree) appears causes a hang/RCU
>> stall for me when hot-unplugging a CPU.
> 
> does this one work for you?
> http://marc.info/?l=linux-mm&m=135929599505624&w=2
> Or try a more recent linux-next. The patch is in akpm's tree.

Yes, that patch fixes the issue for me, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
