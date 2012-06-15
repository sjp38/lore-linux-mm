Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3D02D6B009E
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 10:21:14 -0400 (EDT)
Date: Fri, 15 Jun 2012 08:57:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
In-Reply-To: <87sjdxm7jd.fsf@skywalker.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1206150857150.19708@router.home>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120614141257.GQ27397@tiehlicka.suse.cz> <alpine.DEB.2.00.1206141538060.12773@router.home> <87sjdxm7jd.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Fri, 15 Jun 2012, Aneesh Kumar K.V wrote:

> > But there seems to no need for this patch otherwise someone would have
> > verified that the patch has the intended beneficial effect on performance.
> >
>
> The variable is never modified after boot.

Thats all? There is no performance gain from this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
