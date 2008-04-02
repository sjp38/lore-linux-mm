From: "Mulyadi Santosa" <mulyadi.santosa@gmail.com>
Subject: Re: RFC: swaptrace tool
Date: Wed, 2 Apr 2008 12:52:50 +0700
Message-ID: <f284c33d0804012252i1f76217as2b58407b814d1e47@mail.gmail.com>
References: <20080401212542.1717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <f284c33d0804011823w24898158s5b09256c16d45605@mail.gmail.com>
	 <20080402115000.E130.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <804dabb00804012028j41acca2ya69081bb92c6788d@mail.gmail.com>
	 <47F301E2.6060403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <kernelnewbies-bounce@nl.linux.org>
In-Reply-To: <47F301E2.6060403@gmail.com>
Content-Disposition: inline
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
To: Scott Lovenberg <scott.lovenberg@gmail.com>
Cc: Peter Teoh <htmldeveloper@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kernel Newbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org, Rik van Riel <riel@surriel.com>
List-Id: linux-mm.kvack.org

Hi Scott...

On Wed, Apr 2, 2008 at 10:47 AM, Scott Lovenberg
<scott.lovenberg@gmail.com> wrote:
>  Are you basing it on Least Recently Used?  I seems to remember that Con
> Konilias had added a swapping module to his staircase scheduler...

yes, Con named it swap prefetch but it doesn't tightly related to
Staircase scheduler.

>if I
> remember correctly, it was fairly controversial because it would swap back
> in before the data was needed if the cache pressure was low and the memory
> was freed back up; although I'm not sure if you want pursue paying the swap
> price twice, it seems to make sense that the cost doesn't count if the
> machine is idle anyways and you don't want to wait for a double page fault
> (first for the page table and then for the data itself) when you're
> requesting data.

AFAIK, page table in Linux is never swapped out (they reside in kernel
space and kernel space is locked in RAM all the time). In windows,
maybe...

regards,

Mulyadi.

--
To unsubscribe from this list: send an email with
"unsubscribe kernelnewbies" to ecartis@nl.linux.org
Please read the FAQ at http://kernelnewbies.org/FAQ
