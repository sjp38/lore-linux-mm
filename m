Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id B604A6B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 06:50:31 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so344150yho.2
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 03:50:31 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id o28si604675yhd.216.2014.01.08.03.50.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 03:50:30 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Wed, 8 Jan 2014 17:20:13 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A06091258059
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 17:21:39 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s08Bo4Xw43581678
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 17:20:07 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s08Bo6PW015125
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 17:20:06 +0530
Message-ID: <52CD3D36.1010706@linux.vnet.ibm.com>
Date: Wed, 08 Jan 2014 17:27:42 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of
 empty numa node
References: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140106141300.4e1c950d45c614d6c29bdd8f@linux-foundation.org> <52CD1113.2070003@linux.vnet.ibm.com> <20140108104713.GB8256@quack.suse.cz>
In-Reply-To: <20140108104713.GB8256@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/08/2014 04:17 PM, Jan Kara wrote:
> On Wed 08-01-14 14:19:23, Raghavendra K T wrote:
>> On 01/07/2014 03:43 AM, Andrew Morton wrote:
>>> On Mon,  6 Jan 2014 15:51:55 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
[...]
>> But having said that I am not able to get an idea of sane implementation
>> to solve this readahead failure bug overcoming the anomaly you pointed
>> :(.  hints/ideas.. ?? please let me know.
>    So if we would be happy with just fixing corner cases like this, we might
> use total node memory size to detect them, can't we? If total node memory
> size is 0, we can use 16 MB (or global number of free pages / 2 if we would
> be uneasy with fixed 16 MB limit) as an upperbound...
>

Thanks Honza.

This seems to be more sensible option, I 'll send the patch with that
change (including 16MB limit if nobody disagrees).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
