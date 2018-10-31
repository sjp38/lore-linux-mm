Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE496B000E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 13:01:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id q10-v6so10945677edd.20
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:01:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z6-v6si2814726edm.238.2018.10.31.10.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 10:01:10 -0700 (PDT)
Date: Wed, 31 Oct 2018 18:01:08 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181031170108.GR32673@dhcp22.suse.cz>
References: <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On Wed 31-10-18 15:53:44, Marinko Catovic wrote:
[...]
> Well caching of any operations with find/du is not necessary imho
> anyway, since walking over all these millions of files in that time
> period is really not worth caching at all - if there is a way you
> mentioned to limit the commands there, that would be great.

One possible way would be to run this find/du workload inside a memory
cgroup with high limit set to something reasonable (that will likely
require some tuning). I am not 100% sure that will behave for metadata
mostly workload without almost any pagecache to reclaim so it might turn
out this will result in other issues. But it is definitely worth trying.
-- 
Michal Hocko
SUSE Labs
