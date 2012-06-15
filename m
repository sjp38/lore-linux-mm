Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 054DB6B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 10:33:45 -0400 (EDT)
Date: Fri, 15 Jun 2012 16:33:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
Message-ID: <20120615143342.GE8100@tiehlicka.suse.cz>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120614141257.GQ27397@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1206141538060.12773@router.home>
 <87sjdxm7jd.fsf@skywalker.in.ibm.com>
 <alpine.DEB.2.00.1206150857150.19708@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206150857150.19708@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Fri 15-06-12 08:57:59, Christoph Lameter wrote:
> On Fri, 15 Jun 2012, Aneesh Kumar K.V wrote:
> 
> > > But there seems to no need for this patch otherwise someone would have
> > > verified that the patch has the intended beneficial effect on performance.
> > >
> >
> > The variable is never modified after boot.
> 
> Thats all? There is no performance gain from this change?
 
Is that required in order to put data in the read mostly section?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
