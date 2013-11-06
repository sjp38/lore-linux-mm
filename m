Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id A16146B0127
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 18:50:50 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id r10so232386pdi.4
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 15:50:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.164])
        by mx.google.com with SMTP id hb3si799777pac.123.2013.11.06.15.50.47
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 15:50:48 -0800 (PST)
Message-ID: <527AD5A2.70902@intel.com>
Date: Wed, 06 Nov 2013 15:49:54 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/2] mm: allow to set overcommit ratio more precisely
References: <1382101019-23563-1-git-send-email-jmarchan@redhat.com>	<1382101019-23563-2-git-send-email-jmarchan@redhat.com>	<20131105155319.732dcbefb162c2ee4716ef9d@linux-foundation.org>	<1450211196.19341043.1383727340985.JavaMail.root@redhat.com> <20131106143313.1a368250df917fba0faf56fe@linux-foundation.org>
In-Reply-To: <20131106143313.1a368250df917fba0faf56fe@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/06/2013 02:33 PM, Andrew Morton wrote:
> On Wed, 6 Nov 2013 03:42:20 -0500 (EST) Jerome Marchand <jmarchan@redhat.com> wrote:
>> That was my first version of this patch (actually "kbytes" to avoid
>> overflow).
>> Dave raised the issue that it silently breaks the user interface:
>> overcommit_ratio is zero while the system behaves differently.
> 
> I don't understand that at all.  We keep overcommit_ratio as-is, with
> the same default values and add a different way of altering it.  That
> should be back-compatible?

Reading the old thread, I think my main point was that we shouldn't
output overcommit_ratio=0 when overcommit_bytes>0.  We need to round up
for numbers less than 1 so that folks don't think overcommit_ratio is _off_.

I was really just trying to talk you in to cramming the extra precision
in to the _existing_ sysctl. :)  I don't think bytes vs. ratio is really
that big of a deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
