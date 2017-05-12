Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3706B02EE
	for <linux-mm@kvack.org>; Fri, 12 May 2017 01:56:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so4758728wme.7
        for <linux-mm@kvack.org>; Thu, 11 May 2017 22:56:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o35si2447676edb.318.2017.05.11.22.56.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 May 2017 22:56:56 -0700 (PDT)
Date: Fri, 12 May 2017 07:56:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Kernel problem
Message-ID: <20170512055655.GA6803@dhcp22.suse.cz>
References: <DM5PR15MB13399384EF35EF4451D31C2183ED0@DM5PR15MB1339.namprd15.prod.outlook.com>
 <bbde3fc7-fa8c-7872-1099-44a3c293ffba@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bbde3fc7-fa8c-7872-1099-44a3c293ffba@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Frank Vosberg <frank.vosberg@sscs.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu 11-05-17 09:57:25, Randy Dunlap wrote:
[...]
> I'll let someone else comment on the actual warning message:
> Creating hierarchies with use_hierarchy==0 (flat hierarchy) is considered deprecated. If you believe that your setup is correct, we kindly ask you to contact linux-mm@kvack.org and let us know

Well, this warning just says that using not hierarchical memory cgroup
hierarchy is a bad idea and this behavior will not be supported for ever
(or for v2 cgroup for that matter). It should warn users who are using
old kernels to either change their configuration or complain that they
have a valid usecase for such a configuration so that we can think of an
alternative approach. From the original email it is not clear to me
whether this configuration is intentional or not, though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
