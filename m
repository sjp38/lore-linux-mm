Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 03A766B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 02:14:49 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so4616738eek.8
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 23:14:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si15266346eef.47.2014.01.21.23.14.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 23:14:48 -0800 (PST)
Message-ID: <52DF6FE7.2080901@suse.de>
Date: Wed, 22 Jan 2014 08:14:47 +0100
From: Hannes Reinecke <hare@suse.de>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] really large storage sectors - going beyond 4096
 bytes
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com> <20140122052052.GM10565@ZenIV.linux.org.uk>
In-Reply-To: <20140122052052.GM10565@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <rwheeler@redhat.com>, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On 01/22/2014 06:20 AM, Joel Becker wrote:
> On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler wrote:
>> One topic that has been lurking forever at the edges is the current
>> 4k limitation for file system block sizes. Some devices in
>> production today and others coming soon have larger sectors and it
>> would be interesting to see if it is time to poke at this topic
>> again.
>>
>> LSF/MM seems to be pretty much the only event of the year that most
>> of the key people will be present, so should be a great topic for a
>> joint session.
> 
> Oh yes, I want in on this.  We handle 4k/16k/64k pages "seamlessly," and
> we would want to do the same for larger sectors.  In theory, our code
> should handle it with the appropriate defines updated.
> 
+1

The shingled drive folks would really love us for this.
Plus it would make live really easy for those type of devices.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: J. Hawn, J. Guild, F. Imendorffer, HRB 16746 (AG Nurnberg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
