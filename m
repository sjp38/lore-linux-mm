Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7BB28024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:39:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so19670136wmc.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:39:10 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id f70si3634627wmd.26.2016.09.23.07.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 07:39:09 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b184so3141799wma.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:39:09 -0700 (PDT)
Date: Fri, 23 Sep 2016 16:39:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20160923143907.GT4478@dhcp22.suse.cz>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
 <20160923135051.GQ4478@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160923135051.GQ4478@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Ho <robert.hu@intel.com>
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, oleg@redhat.com, dan.j.williams@intel.com, dave.hansen@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Fri 23-09-16 15:50:51, Michal Hocko wrote:
> On Fri 23-09-16 21:12:33, Robert Ho wrote:
[...]
> > @@ -786,7 +791,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
> >  		   "KernelPageSize: %8lu kB\n"
> >  		   "MMUPageSize:    %8lu kB\n"
> >  		   "Locked:         %8lu kB\n",
> > -		   (vma->vm_end - vma->vm_start) >> 10,
> > +		   (vma->vm_end - max(vma->vm_start, m->version)) >> 10,
> >  		   mss.resident >> 10,
> >  		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
> >  		   mss.shared_clean  >> 10,

And forgot to mention that this is not sufficient either. You also need
to restrict the pte walk to get sane numbers...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
