Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 03B0D6B004D
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 10:50:02 -0400 (EDT)
Date: Fri, 15 Jun 2012 09:50:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
In-Reply-To: <20120615143342.GE8100@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1206150948120.20541@router.home>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120614141257.GQ27397@tiehlicka.suse.cz> <alpine.DEB.2.00.1206141538060.12773@router.home> <87sjdxm7jd.fsf@skywalker.in.ibm.com> <alpine.DEB.2.00.1206150857150.19708@router.home>
 <20120615143342.GE8100@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Fri, 15 Jun 2012, Michal Hocko wrote:

> > Thats all? There is no performance gain from this change?
>
> Is that required in order to put data in the read mostly section?

I thought so. The read_mostly section is specially designed for data that
causes excessive cacheline bounces and has to be grouped with rarely
accessed other data. That was at least the intend when we created it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
