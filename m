Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC156B0038
	for <linux-mm@kvack.org>; Sat, 18 Nov 2017 15:33:52 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id j14so2787472uag.2
        for <linux-mm@kvack.org>; Sat, 18 Nov 2017 12:33:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o19sor2236655vke.242.2017.11.18.12.33.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 18 Nov 2017 12:33:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz>
References: <20171101053244.5218-1-slandden@gmail.com> <20171103063544.13383-1-slandden@gmail.com>
 <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz>
From: Shawn Landden <slandden@gmail.com>
Date: Sat, 18 Nov 2017 12:33:50 -0800
Message-ID: <CA+49okpufRcRD=VfjWkEi_XSc+Uyn+291Npz-K2J34f5AjFxrA@mail.gmail.com>
Subject: Re: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for
 stateless idle loops
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Fri, Nov 3, 2017 at 2:09 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 02-11-17 23:35:44, Shawn Landden wrote:
>> 16 bytes per process is kinda spendy, but I want to keep
>> lru behavior, which mem_score_adj does not allow. When a supervisor,
>> like Android's user input is keeping track this can be done in user-space.
>> It could be pulled out of task_struct if an cross-indexing additional
>> red-black tree is added to support pid-based lookup.
>
> This is still an abuse and the patch is wrong. We really do have an API
> to use I fail to see why you do not use it.
When I looked at wait_queue_head_t it was 20 bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
