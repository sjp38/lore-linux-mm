Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 56ACA6B026D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 18:06:33 -0400 (EDT)
Date: Fri, 22 Jun 2012 15:06:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
Message-Id: <20120622150631.9a7c4d17.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1206150948120.20541@router.home>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120614141257.GQ27397@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1206141538060.12773@router.home>
	<87sjdxm7jd.fsf@skywalker.in.ibm.com>
	<alpine.DEB.2.00.1206150857150.19708@router.home>
	<20120615143342.GE8100@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1206150948120.20541@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com

On Fri, 15 Jun 2012 09:50:00 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 15 Jun 2012, Michal Hocko wrote:
> 
> > > Thats all? There is no performance gain from this change?
> >
> > Is that required in order to put data in the read mostly section?
> 
> I thought so. The read_mostly section is specially designed for data that
> causes excessive cacheline bounces and has to be grouped with rarely
> accessed other data. That was at least the intend when we created it.
> 

The __read_mostly thing really is a bit of a crapshoot.  The runtime
effects are extremely dependent upon Kconfig settings and toolchain
behaviour.  I do recall one or two cases where people did fix
real-world observed performance issues by adding __read_mostly.

Literally "one or two".  We have more than one or two __read_mostly
annotations in there!

As that hugelb_max_hstate is write-once, it's a good candidate.  I'll
apply the patch and hope that it improves someone's kernel somewhere
someday.  Shrug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
