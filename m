Message-ID: <47E29EC6.5050403@goop.org>
Date: Thu, 20 Mar 2008 10:28:38 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 01/15] preparation: provide hook to enable pgstes
 in	user pagetable
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com> <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com>
In-Reply-To: <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Linux Memory Management List <linux-mm@kvack.org>, aliguori@us.ibm.com, EHRHARDT@de.ibm.com, arnd@arndb.de, hollisb@us.ibm.com, heiko.carstens@de.ibm.com, jeroney@us.ibm.com, borntraeger@de.ibm.com, schwidefsky@de.ibm.com, rvdheij@gmail.com, os@de.ibm.com, jblunck@suse.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

Carsten Otte wrote:
> +struct mm_struct *dup_mm(struct task_struct *tsk);
>   

No prototypes in .c files.  Put this in an appropriate header.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
