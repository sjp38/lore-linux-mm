Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 433506B00A9
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:48:01 -0400 (EDT)
Message-ID: <4ABC83E2.7050300@crca.org.au>
Date: Fri, 25 Sep 2009 18:48:34 +1000
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: No more bits in vm_area_struct's vm_flags.
References: <4AB9A0D6.1090004@crca.org.au>	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>	<4ABC80B0.5010100@crca.org.au> <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

KAMEZAWA Hiroyuki wrote:
> On Fri, 25 Sep 2009 18:34:56 +1000
> Nigel Cunningham <ncunningham@crca.org.au> wrote:
> 
>> Hi.
>>
>> KAMEZAWA Hiroyuki wrote:
>>>> I have some code in TuxOnIce that needs a bit too (explicitly mark the
>>>> VMA as needing to be atomically copied, for GEM objects), and am not
>>>> sure what the canonical way to proceed is. Should a new unsigned long be
>>>> added? The difficulty I see with that is that my flag was used in
>>>> shmem_file_setup's flags parameter (drm_gem_object_alloc), so that
>>>> function would need an extra parameter too..
>>> Hmm, how about adding vma->vm_flags2 ?
>> The difficulty there is that some functions pass these flags as arguments.
>>
> Ah yes. But I wonder some special flags, which is rarey used, can be moved
> to vm_flags2...

Ah, of course. That makes sense.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
