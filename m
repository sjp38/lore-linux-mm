Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 577806B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 16:44:12 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so36966366pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 13:44:12 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id pr10si5769563pbb.122.2015.08.27.13.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 13:44:10 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so36965756pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 13:44:10 -0700 (PDT)
Date: Thu, 27 Aug 2015 13:44:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
In-Reply-To: <20150827172351.GA29092@Sligo.logfs.org>
Message-ID: <alpine.DEB.2.10.1508271338580.30543@chino.kir.corp.google.com>
References: <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20150820110004.GB4632@dhcp22.suse.cz> <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp> <20150821065321.GD23723@dhcp22.suse.cz> <20150821163033.GA4600@Sligo.logfs.org>
 <20150824085127.GB17078@dhcp22.suse.cz> <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com> <20150826063813.GA25196@dhcp22.suse.cz> <alpine.DEB.2.10.1508261451540.19139@chino.kir.corp.google.com> <20150827064817.GB14367@dhcp22.suse.cz>
 <20150827172351.GA29092@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-220680865-1440708164=:30543"
Content-ID: <alpine.DEB.2.10.1508271343110.30543@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>
Cc: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-220680865-1440708164=:30543
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.10.1508271343111.30543@chino.kir.corp.google.com>

On Thu, 27 Aug 2015, JA?rn Engel wrote:

> On Thu, Aug 27, 2015 at 08:48:18AM +0200, Michal Hocko wrote:
> > Can we go with the single and much simpler cumulative number first and
> > only add the break down list if it is _really_ required? We can even
> > document that the future version of /proc/<pid>/status might add an
> > additional information to prepare all the parsers to be more careful.
> 
> I don't care much which way we decide.  But I find your reasoning a bit
> worrying.  If someone asks for a by-size breakup of hugepages in a few
> years, you might have existing binaries that depend on the _absence_ of
> those extra characters on the line.
> 
> Compare:
>   HugetlbPages:      18432 kB
>   HugetlbPages:    1069056 kB (1*1048576kB 10*2048kB)
> 
> Once someone has written a script that greps for 'HugetlbPages:.*kB$',
> you have lost the option of adding anything else to the line.  You have
> created yet another ABI compatibility headache today in order to save
> 112 lines of code.
> 

This is exactly the concern that I have brought up in this thread.  We 
have no other way to sanely export the breakdown in hugepage size without 
new fields being added later with the hstate size being embedded in the 
name itself.

I agree with the code as it stands in -mm today and I'm thankful to Naoya 
that a long-term maintainable API has been established.  Respectfully, I 
have no idea why we are still talking about this and I'm not going to be 
responding further unless something changes in -mm.
--397176738-220680865-1440708164=:30543--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
