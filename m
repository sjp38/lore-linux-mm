Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6B36B0006
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 03:32:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h25-v6so10299457eds.21
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 00:32:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5-v6si11088428eje.11.2018.10.31.00.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 00:32:27 -0700 (PDT)
Date: Wed, 31 Oct 2018 08:32:25 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181031072721.GH32673@dhcp22.suse.cz>
References: <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Marinko Catovic <marinko.catovic@gmail.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On Tue 30-10-18 18:00:23, Vlastimil Babka wrote:
[...]
> I suspect there are lots of short-lived processes, so these are probably
> rapidly recycled and not causing compaction. It also seems to be pgd
> allocation (2 pages due to PTI) not kernel stack?

I guess you are right. I have misread order=2 yesterday. order=1 stack
would be quite unexpected.
-- 
Michal Hocko
SUSE Labs
