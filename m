Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADD016B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 12:08:31 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so46697149pgi.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 09:08:31 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g11si7843213plj.315.2017.02.24.09.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 09:08:30 -0800 (PST)
Subject: Re: [PATCH V4 6/6] proc: show MADV_FREE pages info in smaps
References: <cover.1487788131.git.shli@fb.com>
 <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e118502c-6be7-2ca5-bd3c-1f390a3961df@intel.com>
Date: Fri, 24 Feb 2017 09:08:30 -0800
MIME-Version: 1.0
In-Reply-To: <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 02/22/2017 10:50 AM, Shaohua Li wrote:
> @@ -770,6 +774,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   "Private_Dirty:  %8lu kB\n"
>  		   "Referenced:     %8lu kB\n"
>  		   "Anonymous:      %8lu kB\n"
> +		   "LazyFree:       %8lu kB\n"
>  		   "AnonHugePages:  %8lu kB\n"
>  		   "ShmemPmdMapped: %8lu kB\n"
>  		   "Shared_Hugetlb: %8lu kB\n"

I've been as guily of this in the past as anyone, but are we just going
to keep adding fields to smaps forever?  For the vast, vast, majority of
folks, this will simply waste the 21 bytes * nr_vmas that it costs us to
print "LazyFree:       0 kB\n" over and over.

Should we maybe start a habit of not printing an entry when it's "0 kB"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
