Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 2B0386B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 17:04:47 -0400 (EDT)
Date: Thu, 16 May 2013 17:04:43 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [RFC v2 0/2] virtio_balloon: auto-ballooning support
Message-ID: <20130516170443.4612ec32@redhat.com>
In-Reply-To: <51954802.1040309@oracle.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
	<51954802.1040309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On Thu, 16 May 2013 16:56:34 -0400
Sasha Levin <sasha.levin@oracle.com> wrote:

> On 05/09/2013 10:53 AM, Luiz Capitulino wrote:
> > Hi,
> > 
> > This series is a respin of automatic ballooning support I started
> > working on last year. Patch 2/2 contains all relevant technical
> > details and performance measurements results.
> > 
> > This is in RFC state because it's a work in progress.
> 
> Hi Luiz,
> 
> Is there a virtio spec patch I could use to get it implemented on
> kvmtool?

Not yet, this will come with v1. But I got some homework to do before
posting it (more perf tests).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
