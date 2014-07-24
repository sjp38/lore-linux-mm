Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB326B005C
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 14:51:16 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so4185027pde.32
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 11:51:16 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ba2si3419133pdb.387.2014.07.24.11.51.15
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 11:51:15 -0700 (PDT)
Message-ID: <1406227874.2874.3.camel@rzwisler-mobl1.amr.corp.intel.com>
Subject: Re: [PATCH v8 00/22] Support ext4 on NV-DIMMs
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Date: Thu, 24 Jul 2014 12:51:14 -0600
In-Reply-To: <20140723195055.GF6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
	 <53CFDBAE.4040601@gmail.com> <20140723195055.GF6754@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Boaz Harrosh <openosd@gmail.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2014-07-23 at 15:50 -0400, Matthew Wilcox wrote:
> On Wed, Jul 23, 2014 at 06:58:38PM +0300, Boaz Harrosh wrote:
> > Have you please pushed this tree to git hub. It used to be on the prd
> > tree, if you could just add another branch there, it would be cool.
> > (https://github.com/01org/prd)
> 
> Ross handles the care & feeding of that tree ... he'll push that branch
> out soon.

I've updated the master branch of PRD's GitHub repo
(https://github.com/01org/prd) so that it is v3.16-rc6 + DAX v8 + PRD.

- Ross



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
