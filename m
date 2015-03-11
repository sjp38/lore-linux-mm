Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id A9FD7900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 11:27:52 -0400 (EDT)
Received: by obcwp4 with SMTP id wp4so9589456obc.4
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:27:52 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id ix8si2263411obc.59.2015.03.11.08.27.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 08:27:52 -0700 (PDT)
Message-ID: <1426087626.17007.317.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/3] mtrr, x86: Fix MTRR lookup to handle inclusive entry
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 11 Mar 2015 09:27:06 -0600
In-Reply-To: <20150311063205.GC29788@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
	 <1426018997-12936-3-git-send-email-toshi.kani@hp.com>
	 <20150311063205.GC29788@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Wed, 2015-03-11 at 07:32 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > When an MTRR entry is inclusive to a requested range, i.e.
> > the start and end of the request are not within the MTRR
> > entry range but the range contains the MTRR entry entirely,
> > __mtrr_type_lookup() ignores such case because both
> > start_state and end_state are set to zero.
> 
> 'ignores such a case' or 'ignores such cases'.

Changed to 'ignores such a case'.

> > This patch fixes the issue by adding a new flag, inclusive,
> 
> s/inclusive/'inclusive'

Updated.

Thanks!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
