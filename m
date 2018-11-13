Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC2796B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 13:05:04 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s70so32582809qks.4
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:05:04 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f196si4389792qka.61.2018.11.13.10.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 10:05:03 -0800 (PST)
Subject: Re: [PATCH] mm/hugetl.c: keep the page mapping info when
 free_huge_page() hit the VM_BUG_ON_PAGE
References: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
 <20181113130433.GB16182@dhcp22.suse.cz>
 <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <dc39308b-1b9e-0cce-471c-64f94f631f97@oracle.com>
Date: Tue, 13 Nov 2018 10:04:52 -0800
MIME-Version: 1.0
In-Reply-To: <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yongkai Wu <nic.wuyk@gmail.com>, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/13/18 7:12 AM, Yongkai Wu wrote:
> Dear Maintainer,
> Actually i met a VM_BUG_ON_PAGE issue in centos7.4 some days ago.When the issue first happen,
> i just can know that it happen in free_huge_page() when doing soft offline huge page.
> But because page->mapping is set to null,i can not get any further information how the issue happen.
> 
> So i modified the code as the patch show,and apply the new code to our produce line and wait some time,
> then the issue come again.And this time i can know the whole file path which trigger the issue by using 
> crash tool to get the inodea??dentry and so on,that help me to find a way to reproduce the issue quite easily
> and finally found the root cause and solve it.

Thank you for the information and the patch.

As previously stated by Michal, please add some additional information to the
change log (commit message) and fix the formatting of the patch.

Can you tell us more about the root cause of your issue?  What was the issue?
How could you reproduce it?  How did you solve it?
-- 
Mike Kravetz
