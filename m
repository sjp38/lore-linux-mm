Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 625FC6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 10:05:40 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id 15so4719459vea.15
        for <linux-mm@kvack.org>; Sun, 07 Apr 2013 07:05:39 -0700 (PDT)
Message-ID: <51617D37.1020502@gmail.com>
Date: Sun, 07 Apr 2013 10:05:43 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] extend hugepage migration
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com> <5148F830.3070601@gmail.com> <1363815326-urchkyxr-mutt-n-horiguchi@ah.jp.nec.com> <514A4B1C.6020201@gmail.com> <20130321125628.GB6051@dhcp22.suse.cz> <514B9BD8.9050207@gmail.com> <20130322081532.GC31457@dhcp22.suse.cz> <515E2592.7020607@gmail.com> <20130405080828.GA14882@dhcp22.suse.cz> <515E92CA.4000507@gmail.com> <20130405093034.GB31132@dhcp22.suse.cz> <5160BE9E.1050905@gmail.com>
In-Reply-To: <5160BE9E.1050905@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, kosaki.motohiro@gmail.com

>> Please refer to hugetlb_fault for more information.
> 
> Thanks for your pointing out. So my assume is correct, is it? Can pmd 
> which support 2MB map 32MB pages work well?

Simon, Please stop hijaking unrelated threads. This is not question and answer thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
