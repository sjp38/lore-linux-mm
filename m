Message-ID: <47E896EA.5060309@de.ibm.com>
Date: Tue, 25 Mar 2008 07:08:42 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC/PATCH 01/15] preparation: provide	hook	to	enable
 pgstes in user pagetable
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com>	 <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com>	 <47E29EC6.5050403@goop.org>	<1206040405.8232.24.camel@nimitz.home.sr71.net>	 <47E2CAAC.6020903@de.ibm.com>	 <1206124176.30471.27.camel@nimitz.home.sr71.net>	 <20080322175705.GD6367@osiris.boeblingen.de.ibm.com>	 <47E62DBA.4050102@qumranet.com> <1206296609.10233.5.camel@localhost> <47E750ED.7060509@qumranet.com>
In-Reply-To: <47E750ED.7060509@qumranet.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: schwidefsky@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Christian Ehrhardt <EHRHARDT@de.ibm.com>, hollisb@us.ibm.com, arnd@arndb.de, Linux Memory Management List <linux-mm@kvack.org>, carsteno@de.ibm.com, heicars2@linux.vnet.ibm.com, mschwid2@linux.vnet.ibm.com, jeroney@us.ibm.com, borntrae@linux.vnet.ibm.com, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, rvdheij@gmail.com, Olaf Schnapper <os@de.ibm.com>, jblunck@suse.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Well, dup_mm() can't work (and now that I think about it, for more 
> reasons -- what if the process has threads?).
We lock out multithreaded users already, -EINVAL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
