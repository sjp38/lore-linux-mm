Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 029776B0163
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 06:28:09 -0400 (EDT)
Received: by obhx4 with SMTP id x4so2326469obh.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 03:28:08 -0700 (PDT)
Message-ID: <1340360943.27031.34.camel@lappy>
Subject: Re: Early boot panic on machine with lots of memory
From: Sasha Levin <levinsasha928@gmail.com>
Date: Fri, 22 Jun 2012 12:29:03 +0200
In-Reply-To: <20120621201935.GC4642@google.com>
References: <1339623535.3321.4.camel@lappy>
	 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	 <1339667440.3321.7.camel@lappy> <20120618223203.GE32733@google.com>
	 <1340059850.3416.3.camel@lappy> <20120619041154.GA28651@shangw>
	 <20120619212059.GJ32733@google.com> <20120621201935.GC4642@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 2012-06-21 at 13:19 -0700, Tejun Heo wrote:
> Hello,
> 
> Sasha, can you please apply the following patch and verify that the
> issue is gone?

That did the trick.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
