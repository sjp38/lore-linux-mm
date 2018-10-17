Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCE406B0006
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:19:16 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d69-v6so20359225pgc.22
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:19:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e12-v6si17272679pls.389.2018.10.17.09.19.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 09:19:15 -0700 (PDT)
Date: Wed, 17 Oct 2018 09:19:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 1/2] mm: Add an F_SEAL_FS_WRITE seal to memfd
Message-ID: <20181017161906.GA5096@infradead.org>
References: <20181009222042.9781-1-joel@joelfernandes.org>
 <20181017095155.GA354@infradead.org>
 <20181017103958.GB230639@joelaf.mtv.corp.google.com>
 <20181017120829.GA19731@infradead.org>
 <CAKOZuesr_8vrob-XfEpGmyeKFEhWWXZo4BEC0PixfjT2ibaRZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesr_8vrob-XfEpGmyeKFEhWWXZo4BEC0PixfjT2ibaRZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Joel Fernandes <joel@joelfernandes.org>, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@android.com, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@google.com>, Shuah Khan <shuah@kernel.org>

On Wed, Oct 17, 2018 at 08:44:01AM -0700, Daniel Colascione wrote:
> > Even if no one changes these specific flags we still need a lock due
> > to rmw cycles on the field.  For example fadvise can set or clear
> > FMODE_RANDOM.  It seems to use file->f_lock for synchronization.
> 
> Compare-and-exchange will suffice, right?

Only if all users use the compare and exchange, and right now they
don't.
