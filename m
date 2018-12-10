Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8913A8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 16:30:54 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w16so3961151wrk.10
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 13:30:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h6sor98010wmc.2.2018.12.10.13.30.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 13:30:53 -0800 (PST)
MIME-Version: 1.0
References: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz> <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz> <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz> <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz> <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <3173eba8-8d7a-b9d7-7d23-38e6008ce2d6@suse.cz> <CADF2uSre7NPvKuEN-Lx5sQ3TzwRuZiupf6kxs0WnFgV5u9z+Jg@mail.gmail.com>
In-Reply-To: <CADF2uSre7NPvKuEN-Lx5sQ3TzwRuZiupf6kxs0WnFgV5u9z+Jg@mail.gmail.com>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Mon, 10 Dec 2018 22:30:40 +0100
Message-ID: <CADF2uSoRoMvq5V-W8p3MX-wYQOeJ-ypXW2oiX0rWEm8v0h4d4A@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

> Currently I fail to manage this, since I do not know how to do step 2.
> echo $PID > tasks writes into it and adds the PID, but how would one
> remove the wrapper script's PID from there?

any ideas on this perhaps?
The workaround, otherwise working perfectly fine, causes huge problems there
since I have to exclude certain processes from that tasklist.

Basically I'd need to know how to remove a PID from the mountpoint, created by

mount -t cgroup -o memory none $SOME_MOUNTPOINT
mkdir $SOME_MOUNTPOINT/A
echo 500M > $SOME_MOUNTPOINT/A/memory.limit_in_bytes

aka remove a specific PID from $SOME_MOUNTPOINT/A/tasks
