Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id AECEE828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:47:31 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so55558413lbb.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 03:47:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x9si6523127wjp.69.2016.06.23.03.47.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 03:47:30 -0700 (PDT)
Date: Thu, 23 Jun 2016 12:47:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3] dax: Clear dirty entry tags on cache flush
Message-ID: <20160623104728.GA25982@quack2.suse.cz>
References: <1466523915-14644-1-git-send-email-jack@suse.cz>
 <1466523915-14644-4-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Content-Disposition: inline
In-Reply-To: <1466523915-14644-4-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

the previous version had a bug which manifested itself on i586. Attached is
a new version for the patch if someone is interested.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--2oS5YaxWCcQjTEyO
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0003-dax-Clear-dirty-entry-tags-on-cache-flush.patch"


--2oS5YaxWCcQjTEyO--
