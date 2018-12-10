Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABCBF8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 16:47:39 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so4806764edm.20
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 13:47:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q47si2828489edd.98.2018.12.10.13.47.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 13:47:38 -0800 (PST)
Date: Mon, 10 Dec 2018 22:47:36 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181210214736.GY1286@dhcp22.suse.cz>
References: <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <3173eba8-8d7a-b9d7-7d23-38e6008ce2d6@suse.cz>
 <CADF2uSre7NPvKuEN-Lx5sQ3TzwRuZiupf6kxs0WnFgV5u9z+Jg@mail.gmail.com>
 <CADF2uSoRoMvq5V-W8p3MX-wYQOeJ-ypXW2oiX0rWEm8v0h4d4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSoRoMvq5V-W8p3MX-wYQOeJ-ypXW2oiX0rWEm8v0h4d4A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On Mon 10-12-18 22:30:40, Marinko Catovic wrote:
> > Currently I fail to manage this, since I do not know how to do step 2.
> > echo $PID > tasks writes into it and adds the PID, but how would one
> > remove the wrapper script's PID from there?
> 
> any ideas on this perhaps?
> The workaround, otherwise working perfectly fine, causes huge problems there
> since I have to exclude certain processes from that tasklist.

I am sorry, I didn't get to your previous email. But this is quite
simply. You just echo those pids to a different cgroup. E.g. the root
one at the top of the mounted hierarchy. There are also wrappers to
execute a task into a specific cgroup in libcgroup package and I am
pretty sure systemd has its own mechanisms to achieve the same.
-- 
Michal Hocko
SUSE Labs
