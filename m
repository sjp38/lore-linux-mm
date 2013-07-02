Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 0931D6B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 00:43:16 -0400 (EDT)
Message-ID: <51D25A71.3060007@sr71.net>
Date: Mon, 01 Jul 2013 21:43:29 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
References: <20130627231605.8F9F12E6@viggo.jf.intel.com> <20130628054757.GA10429@gmail.com> <51CDB056.5090308@sr71.net> <51CE4451.4060708@gmail.com> <51D1AB6E.9030905@sr71.net> <20130702023748.GA10366@gmail.com>
In-Reply-To: <20130702023748.GA10366@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/01/2013 07:37 PM, Zheng Liu wrote:
> FWIW, it would be great if we can let MAP_POPULATE flag support shared
> mappings because in our product system there has a lot of applications
> that uses mmap(2) and then pre-faults this mapping.  Currently these
> applications need to pre-fault the mapping manually.

Are you sure it doesn't?  From a cursory look at the code, it looked to
me like it would populate anonymous and file-backed, but I didn't
double-check experimentally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
