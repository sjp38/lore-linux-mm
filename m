From: "Tim Pepper" <lnxninja@us.ibm.com>
Subject: Re: [PATCH] Fix sparsemem on Cell (take 3)
Date: Sun, 7 Jan 2007 22:31:14 -0800
Message-ID: <eada2a070701072231h6501fe9pcda8da51b1ecfb41@mail.gmail.com>
References: <20061215165335.61D9F775@localhost.localdomain>
	<200612182354.47685.arnd@arndb.de>
	<1166483780.8648.26.camel@localhost.localdomain>
	<200612190959.47344.arnd@arndb.de>
	<1168045803.8945.14.camel@localhost.localdomain>
	<1168059162.23226.1.camel@sinatra.austin.ibm.com>
	<1168160307.6740.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0503785158=="
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1168160307.6740.9.camel@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, mkravetz@us.ibm.com, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, hch@infradead.org, External List <linuxppc-dev@ozlabs.org>, Paul Mackerras <paulus@samba.org>, kmannth@us.ibm.com, gone@us.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

--===============0503785158==
Content-Type: multipart/alternative;
	boundary="----=_Part_59152_16376959.1168237874232"

------=_Part_59152_16376959.1168237874232
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 1/7/07, Dave Hansen <haveblue@us.ibm.com> wrote:
>
> On Fri, 2007-01-05 at 22:52 -0600, John Rose wrote:
>
> > Could this break ia64, given that it uses memmap_init_zone()?
>
> You are right, I think it does.
>
> Here's an updated patch to replace the earlier one.  I had to move the
> enum definition over to a different header because ia64 evidently has a
> different include order.


Boot tested OK on ia64 with this latest version of the patch.

Tim

------=_Part_59152_16376959.1168237874232
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 1/7/07, <b class="gmail_sendername">Dave Hansen</b> &lt;<a href="mailto:haveblue@us.ibm.com">haveblue@us.ibm.com</a>&gt; wrote:<div><span class="gmail_quote"></span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Fri, 2007-01-05 at 22:52 -0600, John Rose wrote:<br><br>&gt; Could this break ia64, given that it uses memmap_init_zone()?<br><br>You are right, I think it does.<br><br>Here&#39;s an updated patch to replace the earlier one.&nbsp;&nbsp;I had to move the
<br>enum definition over to a different header because ia64 evidently has a<br>different include order.</blockquote><div><br>Boot tested OK on ia64 with this latest version of the patch.<br><br>Tim<br></div><br></div>

------=_Part_59152_16376959.1168237874232--

--===============0503785158==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0503785158==--
