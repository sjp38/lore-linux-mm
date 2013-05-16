Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7A4F86B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 16:56:59 -0400 (EDT)
Message-ID: <51954802.1040309@oracle.com>
Date: Thu, 16 May 2013 16:56:34 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 0/2] virtio_balloon: auto-ballooning support
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On 05/09/2013 10:53 AM, Luiz Capitulino wrote:
> Hi,
> 
> This series is a respin of automatic ballooning support I started
> working on last year. Patch 2/2 contains all relevant technical
> details and performance measurements results.
> 
> This is in RFC state because it's a work in progress.

Hi Luiz,

Is there a virtio spec patch I could use to get it implemented on
kvmtool?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
