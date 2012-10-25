Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id A649D6B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 22:38:11 -0400 (EDT)
Date: Thu, 25 Oct 2012 10:38:08 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
Message-ID: <20121025023808.GA23462@localhost>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
 <20121023224706.GR4291@dastard>
 <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
 <20121024201921.GX4291@dastard>
 <CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
 <20121025015014.GC29378@dastard>
 <CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YingHang Zhu <casualfisher@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi YingHang,

> Actually I've talked about it with Fengguang, he advised we should unify the
> ra_pages in struct bdi and file_ra_state and leave the issue that
> spreading data
> across disks as it is.
> Fengguang, what's you opinion about this?

Yeah the two ra_pages may run out of sync for already opened files,
which could be a problem for long opened files. However as Dave put
it, a device's max readahead size is typically a static value that can
be set at mount time. So, the question is: do you really hurt from the
old behavior that deserves this code change?

I agree with Dave that the multi-disk case is not a valid concern.  In
fact, how can the patch help that case? I mean, if it's two fuse files
lying in two disks, it *was* not a problem at all. If it's one big
file spreading to two disks, it's a too complex scheme to be
practically manageable which I doubt if you have such a setup. 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
