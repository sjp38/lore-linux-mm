Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E46516B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 10:06:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d185so3866775pgc.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 07:06:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x184si25195978pfx.299.2017.01.17.07.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 07:06:42 -0800 (PST)
Date: Tue, 17 Jan 2017 07:06:38 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
Message-ID: <20170117150638.GA3747@infradead.org>
References: <20170114002008.GA25379@linux.intel.com>
 <20170114082621.GC10498@birch.djwong.org>
 <x49wpduzseu.fsf@dhcp-25-115.bos.redhat.com>
 <20170117015033.GD10498@birch.djwong.org>
 <20170117075735.GB19654@infradead.org>
 <x49mvep4tzw.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49mvep4tzw.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 17, 2017 at 09:54:27AM -0500, Jeff Moyer wrote:
> I spoke with Dave before the holidays, and he indicated that
> PMEM_IMMUTABLE would be an acceptable solution to allowing applications
> to flush data completely from userspace.  I know this subject has been
> beaten to death, but would you mind just summarizing your opinion on
> this one more time?  I'm guessing this will be something more easily
> hashed out at LSF, though.

Come up with a prototype that doesn't suck and allows all fs features to
actually work.  And show an application that actually cares and shows
benefits on publicly available real hardware.  Until then go away and
stop wasting everyones time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
