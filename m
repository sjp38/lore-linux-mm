From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: swaptrace tool
Date: Wed, 02 Apr 2008 11:58:46 +0900
Message-ID: <20080402115000.E130.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080401212542.1717.KOSAKI.MOTOHIRO@jp.fujitsu.com> <f284c33d0804011823w24898158s5b09256c16d45605@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <kernelnewbies-bounce@nl.linux.org>
In-Reply-To: <f284c33d0804011823w24898158s5b09256c16d45605@mail.gmail.com>
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
To: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Teoh <htmldeveloper@gmail.com>, Kernel Newbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi

> >  hmm,
> >  I can't find it from mailing list log.
> >  Could you recall subject of that patch?
> 
> here is the URL http://lkml.org/lkml/2006/8/4/77

Oh! thanks.
but, this patch only get per process # of swap pages.

and the following patch is merged -mm before a while.
http://marc.info/?l=linux-kernel&m=120654533828554&w=2

thus, now we have its capability via /proc/pid/smap.

in my understanding, originally requirement wanted following tuple.

  - destination begin offset / size
  - source begin offset / size
  - process/task


Thanks.



--
To unsubscribe from this list: send an email with
"unsubscribe kernelnewbies" to ecartis@nl.linux.org
Please read the FAQ at http://kernelnewbies.org/FAQ
