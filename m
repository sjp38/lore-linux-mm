Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id A86176B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 10:43:52 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so5085742qcx.30
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 07:43:52 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id u9si19332879qap.74.2014.01.13.07.43.45
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 07:43:46 -0800 (PST)
Message-ID: <52D40957.2020103@sr71.net>
Date: Mon, 13 Jan 2014 07:42:15 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
References: <20140103180147.6566F7C1@viggo.jf.intel.com> <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org> <20140106043237.GE696@lge.com> <52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org> <52D0854F.5060102@sr71.net> <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com> <alpine.DEB.2.10.1401111854580.6036@nuc> <20140113014408.GA25900@lge.com> <1389584218.11984.0.camel@buesod1.americas.hpqcorp.net> <20140113134609.GB31640@localhost>
In-Reply-To: <20140113134609.GB31640@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Davidlohr Bueso <davidlohr@hp.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/13/2014 05:46 AM, Fengguang Wu wrote:
>>> So, I think
>>> that it is better to get more benchmark results to this patchset for convincing
>>> ourselves. If possible, how about asking Fengguang to run whole set of
>>> his benchmarks before going forward?
>>
>> Cc'ing him.
> 
> My pleasure. Is there a git tree for the patches? Git trees
> are most convenient for running automated tests and bisects.

Here's a branch:

https://github.com/hansendc/linux/tree/slub-reshrink-for-Fengguang-20140113

My patches are not broken out in there, but that's all the code that
needs to get tested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
