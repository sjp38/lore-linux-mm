Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F025F6B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 14:04:25 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id uo6so105469040pac.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 11:04:25 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id v86si3507419pfi.16.2016.02.02.11.04.24
        for <linux-mm@kvack.org>;
        Tue, 02 Feb 2016 11:04:25 -0800 (PST)
Subject: Re: [PATCH 22/31] x86, pkeys: dump pkey from VMA in /proc/pid/smaps
References: <20160129181642.98E7D468@viggo.jf.intel.com>
 <20160129181713.3F22714C@viggo.jf.intel.com> <56B0D54C.3010901@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56B0FDB7.4070500@sr71.net>
Date: Tue, 2 Feb 2016 11:04:23 -0800
MIME-Version: 1.0
In-Reply-To: <56B0D54C.3010901@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com

On 02/02/2016 08:11 AM, Vlastimil Babka wrote:
>> +void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct
>> *vma)
>> +{
>> +}
> 
> Is it valid that this serves also as a declaration? Or should it be also
> in some header?

I guess having it in a header would make it less likely that someone
screws up a definition farther down the line.  But, it also seemed a wee
bit of overkill for a single user.

I'm happy to send a follow-on patch to add it to a header somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
