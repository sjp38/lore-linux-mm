Date: Sat, 12 Apr 2008 03:26:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
In-Reply-To: <20080412094118.GA7708@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0804120325001.23255@schroedinger.engr.sgi.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com>
 <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com>
 <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 12 Apr 2008, Nick Piggin wrote:

> Can you comment on the aspect of configuring various kernel hugetlb 
> configuration parameters? Especifically, what directory it should go in?
> IMO it should be /sys/kernel/*

Yes that would be more consistent. However, it will break the tools that 
now access /sys/devices.

Something like

/sys/kernel/node/<nodenr>/<numa setting>

and

/sys/kernel/memory/<global setting>

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
