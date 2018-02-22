Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28A286B0003
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 16:24:45 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v16so4225123wrv.14
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 13:24:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c3si656427wre.486.2018.02.22.13.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 13:24:44 -0800 (PST)
Date: Thu, 22 Feb 2018 13:24:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] mm/sparse: Add a static variable
 nr_present_sections
Message-Id: <20180222132441.51a8eae9e9656a82a2161070@linux-foundation.org>
In-Reply-To: <20180222091130.32165-2-bhe@redhat.com>
References: <20180222091130.32165-1-bhe@redhat.com>
	<20180222091130.32165-2-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, dave.hansen@intel.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de

On Thu, 22 Feb 2018 17:11:28 +0800 Baoquan He <bhe@redhat.com> wrote:

> It's used to record how many memory sections are marked as present
> during system boot up, and will be used in the later patch.
> 
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -202,6 +202,7 @@ static inline int next_present_section_nr(int section_nr)
>  	      (section_nr <= __highest_present_section_nr));	\
>  	     section_nr = next_present_section_nr(section_nr))
>  
> +static int nr_present_sections;

I think this could be __initdata.

A nice comment explaining why it exists would be nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
