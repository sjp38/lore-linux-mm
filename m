Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 242346B005D
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 17:13:11 -0400 (EDT)
Received: by iec9 with SMTP id 9so4994688iec.14
        for <linux-mm@kvack.org>; Mon, 03 Sep 2012 14:13:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLG3DVocuakT91vmgKWFME94PL9_XAqGM_=jru-Tbg4oPw@mail.gmail.com>
References: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
	<CAOJsxLG3DVocuakT91vmgKWFME94PL9_XAqGM_=jru-Tbg4oPw@mail.gmail.com>
Date: Mon, 3 Sep 2012 18:13:10 -0300
Message-ID: <CALF0-+VOLiFmh=pLArm9LUtBOZtzqYSMxRS_Qb7t9Zv8ur61mQ@mail.gmail.com>
Subject: Re: [PATCH] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Matt Mackall <mpm@selenic.com>

Hi Pekka,

On Wed, Aug 15, 2012 at 8:43 AM, Pekka Enberg <penberg@kernel.org> wrote:
> On Tue, Aug 14, 2012 at 11:03 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
>> This field was being used to store size allocation so it could be
>> retrieved by ksize(). However, it is a bad practice to not mark a page
>> as a slab page and then use fields for special purposes.
>> There is no need to store the allocated size and
>> ksize() can simply return PAGE_SIZE << compound_order(page).
>>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Glauber Costa <glommer@parallels.com>
>> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
>
> Looks good to me. Matt?
>

Will you carry this (and the other 3 patches I sent for mm/) on your tree?
Or do I need to send them to someone else?

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
