Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 845B86B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 14:42:39 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id n184so92329218oig.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 11:42:39 -0800 (PST)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id 64si18844139otn.83.2016.11.24.11.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 11:42:38 -0800 (PST)
Received: by mail-oi0-x236.google.com with SMTP id b126so60367310oia.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 11:42:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161124091140.GB24138@quack2.suse.cz>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-3-git-send-email-ross.zwisler@linux.intel.com> <20161124091140.GB24138@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Nov 2016 11:42:38 -0800
Message-ID: <CAPcyv4g=4OAskS3x31H5yx0T+suDbpwQpSyDtb+36rwmKCGMng@mail.gmail.com>
Subject: Re: [PATCH 2/6] dax: remove leading space from labels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Thu, Nov 24, 2016 at 1:11 AM, Jan Kara <jack@suse.cz> wrote:
> On Wed 23-11-16 11:44:18, Ross Zwisler wrote:
>> No functional change.
>>
>> As of this commit:
>>
>> commit 218dd85887da (".gitattributes: set git diff driver for C source code
>> files")
>>
>> git-diff and git-format-patch both generate diffs whose hunks are correctly
>> prefixed by function names instead of labels, even if those labels aren't
>> indented with spaces.
>
> Fine by me. I just have some 4 remaining DAX patches (will send them out
> today) and they will clash with this. So I'd prefer if this happened after
> they are merged...

Let's just leave them alone, it's not like this thrash buys us
anything at this point.  We can just stop including spaces in new
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
