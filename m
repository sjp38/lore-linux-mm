Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC536B0003
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 10:35:44 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 191-v6so5221727ywg.10
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 07:35:44 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id p132-v6si1135338ybc.254.2018.10.04.07.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Oct 2018 07:35:43 -0700 (PDT)
Date: Thu, 4 Oct 2018 10:35:38 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] mm: Fix warning in insert_pfn()
Message-ID: <20181004143538.GE646@thunk.org>
References: <20180824154542.26872-1-jack@suse.cz>
 <20181003163557.GA18434@thunk.org>
 <CAPcyv4hxxcC6dkeN80MXaHx9A-kw1fn=Yjqi5uGRdFueVRFXbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hxxcC6dkeN80MXaHx9A-kw1fn=Yjqi5uGRdFueVRFXbg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>

On Wed, Oct 03, 2018 at 09:56:09AM -0700, Dan Williams wrote:
> 
> It's in Andrew's tree. I believe we are awaiting the next -next
> release to rebase on latest mmotm.

Great, thanks for the update!

					- Ted
