Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3880B6B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:25:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so6097766edd.16
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 07:25:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o21-v6si1350964ejn.182.2018.11.13.07.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 07:25:00 -0800 (PST)
Date: Tue, 13 Nov 2018 16:24:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hugetl.c: keep the page mapping info when
 free_huge_page() hit the VM_BUG_ON_PAGE
Message-ID: <20181113152459.GR15120@dhcp22.suse.cz>
References: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
 <20181113130433.GB16182@dhcp22.suse.cz>
 <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yongkai Wu <nic.wuyk@gmail.com>
Cc: mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[Please do not top-post]

On Tue 13-11-18 23:12:24, Yongkai Wu wrote:
> Dear Maintainer,
> Actually i met a VM_BUG_ON_PAGE issue in centos7.4 some days ago.When the
> issue first happen,
> i just can know that it happen in free_huge_page() when doing soft offline
> huge page.
> But because page->mapping is set to null,i can not get any further
> information how the issue happen.
> 
> So i modified the code as the patch show,and apply the new code to our
> produce line and wait some time,
> then the issue come again.And this time i can know the whole file path
> which trigger the issue by using
> crash tool to get the inodea??dentry and so on,that help me to find a way to
> reproduce the issue quite easily
> and finally found the root cause and solve it.

OK, thanks for the clarification. Please repost without
the patch being clobbered by your email client and feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

A note about your experience in the changelog would be useful IMHO.
-- 
Michal Hocko
SUSE Labs
