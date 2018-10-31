Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 458D96B0008
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 15:21:56 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id j127-v6so13489045wmd.3
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:21:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x18-v6sor5864244wmh.6.2018.10.31.12.21.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 12:21:55 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz> <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz> <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz> <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com> <20181031170108.GR32673@dhcp22.suse.cz>
In-Reply-To: <20181031170108.GR32673@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Wed, 31 Oct 2018 20:21:42 +0100
Message-ID: <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

Am Mi., 31. Okt. 2018 um 18:01 Uhr schrieb Michal Hocko <mhocko@suse.com>:
>
> On Wed 31-10-18 15:53:44, Marinko Catovic wrote:
> [...]
> > Well caching of any operations with find/du is not necessary imho
> > anyway, since walking over all these millions of files in that time
> > period is really not worth caching at all - if there is a way you
> > mentioned to limit the commands there, that would be great.
>
> One possible way would be to run this find/du workload inside a memory
> cgroup with high limit set to something reasonable (that will likely
> require some tuning). I am not 100% sure that will behave for metadata
> mostly workload without almost any pagecache to reclaim so it might turn
> out this will result in other issues. But it is definitely worth trying.

hm, how would that be possible..? every user has its UID, the group
can also not be a factor, since this memory restriction would apply to
all users then, find/du are running as UID 0 to have access to
everyone's data.

so what is the conclusion from this issue now btw? is it something
that will be changed/fixed at any time?
As I understand everyone would have this issue when extensive walking
over files is performed, basically any `cloud`, shared hosting or
storage systems should experience it, true?
