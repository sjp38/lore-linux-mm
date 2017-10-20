Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD4386B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 17:52:28 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id i133so745284vke.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 14:52:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j60sor816247uad.40.2017.10.20.14.52.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 14:52:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020131142.z7kxvmlukg4z2shv@dhcp22.suse.cz>
References: <20171018063123.21983-1-bsingharora@gmail.com> <20171020131142.z7kxvmlukg4z2shv@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sat, 21 Oct 2017 08:52:27 +1100
Message-ID: <CAKTCnzn4oh1807rwm3yF4THgn79ps35_OKcOTmKA8wfw=KULaw@mail.gmail.com>
Subject: Re: [rfc 1/2] mm/hmm: Allow smaps to see zone device public pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>

On Sat, Oct 21, 2017 at 12:11 AM, Michal Hocko <mhocko@suse.com> wrote:
> On Wed 18-10-17 17:31:22, Balbir Singh wrote:
>> vm_normal_page() normally does not return zone device public
>> pages. In the absence of the visibility the output from smaps
>> is limited and confusing. It's hard to figure out where the
>> pages are. This patch uses _vm_normal_page() to expose them
>> for accounting
>
> Maybe I am missing something but does this patch make any sense without
> patch 2? If no why they are not folded into a single one?


I can fold them into one patch. The first patch when applied will just provide
visibility and they'll show as regular resident pages. The second patch
then accounts only for them being device memory.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
