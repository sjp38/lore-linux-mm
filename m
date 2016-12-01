Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 582D728025A
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 10:35:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so101847296pgx.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:35:02 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a188si573223pfb.180.2016.12.01.07.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 07:35:01 -0800 (PST)
Date: Thu, 1 Dec 2016 08:35:00 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 1/6] tracing: add __print_flags_u64()
Message-ID: <20161201153500.GB5160@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
 <1480549533-29038-2-git-send-email-ross.zwisler@linux.intel.com>
 <20161201091254.3e9f99b0@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201091254.3e9f99b0@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Dec 01, 2016 at 09:12:54AM -0500, Steven Rostedt wrote:
> On Wed, 30 Nov 2016 16:45:28 -0700
> Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> > diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
> > index 3fc2042..ed4398f 100644
> > --- a/kernel/trace/trace_output.c
> > +++ b/kernel/trace/trace_output.c
> > @@ -124,6 +124,44 @@ EXPORT_SYMBOL(trace_print_symbols_seq);
> >  
> >  #if BITS_PER_LONG == 32
> >  const char *
> > +trace_print_flags_seq_u64(struct trace_seq *p, const char *delim,
> > +		      unsigned long long flags,
> > +		      const struct trace_print_flags_u64 *flag_array)
> > +{
> > +	unsigned long mask;
> 
> Don't you want mask to be unsigned long long?

Yep, thanks for spotting that.  I'll fix it in v3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
