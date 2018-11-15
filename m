Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1B66B0269
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:52:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so3516943eda.12
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:52:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e11si96064edl.89.2018.11.15.00.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:52:29 -0800 (PST)
Date: Thu, 15 Nov 2018 09:52:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hugetl.c: keep the page mapping info when
 free_huge_page() hit the VM_BUG_ON_PAGE
Message-ID: <20181115085227.GG23831@dhcp22.suse.cz>
References: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
 <20181113130433.GB16182@dhcp22.suse.cz>
 <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
 <dc39308b-1b9e-0cce-471c-64f94f631f97@oracle.com>
 <CAJtqMcYzA6c1pTrWPcPETsJchOjpJS8iXVhDAJyWuVGCA4gKuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJtqMcYzA6c1pTrWPcPETsJchOjpJS8iXVhDAJyWuVGCA4gKuA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yongkai Wu <nic.wuyk@gmail.com>
Cc: mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-11-18 16:30:32, Yongkai Wu wrote:
[...]

Thanks for the clarification. It can be helpful for somebody trying to
debug a similar issue in the future.

> But i can not find a similar bug fix report or commit log.

What about 6bc9b56433b7 ("mm: fix race on soft-offlining free huge pages") ?

-- 
Michal Hocko
SUSE Labs
